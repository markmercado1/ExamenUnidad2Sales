from rest_framework import viewsets, mixins
from rest_framework.response import Response
from rest_framework import status

from apps.sale.models import Sale
from apps.sale.serializers import SaleReadSerializer, SaleWriteSerializer


class SaleViewSet(mixins.CreateModelMixin,
                  mixins.ListModelMixin,
                  mixins.RetrieveModelMixin,
                  viewsets.GenericViewSet):
    """
    Ventas: solo create, list y retrieve.
    Las ventas no se editan ni eliminan.
    """
    queryset = Sale.objects.select_related('client').prefetch_related(
        'details__product__category'
    ).all()

    def get_serializer_class(self):
        if self.action == 'create':
            return SaleWriteSerializer
        return SaleReadSerializer

    def create(self, request, *args, **kwargs):
        write_serializer = SaleWriteSerializer(data=request.data)
        write_serializer.is_valid(raise_exception=True)
        sale = write_serializer.save()

        read_serializer = SaleReadSerializer(sale)
        return Response(read_serializer.data, status=status.HTTP_201_CREATED)