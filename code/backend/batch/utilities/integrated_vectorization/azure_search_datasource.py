from azure.search.documents.indexes.models import (
    SearchIndexerDataContainer,
    SearchIndexerDataSourceConnection,
)
from azure.search.documents.indexes._generated.models import (
    NativeBlobSoftDeleteDeletionDetectionPolicy,
)
from azure.search.documents.indexes import SearchIndexerClient
from ..helpers.env_helper import EnvHelper
from ..helpers.azure_credential_utils import get_azure_credential

class AzureSearchDatasource:
    def __init__(self, env_helper: EnvHelper):
        self.env_helper = env_helper
        self.indexer_client = SearchIndexerClient(
            self.env_helper.AZURE_SEARCH_SERVICE,
            get_azure_credential(),
        )

    def create_or_update_datasource(self):
        connection_string = self.generate_datasource_connection_string()
        container = SearchIndexerDataContainer(
            name=self.env_helper.AZURE_BLOB_CONTAINER_NAME
        )
        data_source_connection = SearchIndexerDataSourceConnection(
            name=self.env_helper.AZURE_SEARCH_DATASOURCE_NAME,
            type="azureblob",
            connection_string=connection_string,
            container=container,
            data_deletion_detection_policy=NativeBlobSoftDeleteDeletionDetectionPolicy(),
        )
        self.indexer_client.create_or_update_data_source_connection(
            data_source_connection
        )

    def generate_datasource_connection_string(self):
        # Always use ResourceId-based connection string (for RBAC/Azure AD)
        return (
            f"ResourceId=/subscriptions/{self.env_helper.AZURE_SUBSCRIPTION_ID}"
            f"/resourceGroups/{self.env_helper.AZURE_RESOURCE_GROUP}"
            f"/providers/Microsoft.Storage/storageAccounts/{self.env_helper.AZURE_BLOB_ACCOUNT_NAME}/;"
        )
