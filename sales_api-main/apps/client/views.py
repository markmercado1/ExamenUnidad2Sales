from rest_framework import viewsets
from apps.client.models import Client
from apps.client.serializers import ClientSerializer


class ClientViewSet(viewsets.ModelViewSet):
    queryset = Client.objects.all()
    serializer_class = ClientSerializer