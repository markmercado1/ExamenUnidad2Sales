from rest_framework import viewsets
from apps.provider.models import Provider
from apps.provider.serializers import ProviderSerializer


class ProviderViewSet(viewsets.ModelViewSet):
    queryset = Provider.objects.all()
    serializer_class = ProviderSerializer