from apps.product.models import Product, Category
from apps.product.serializers import ProductReadSerializer, ProductWriteSerializer, CategorySerializer
from rest_framework import viewsets


class ProductModelViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all()

    def get_serializer_class(self):
        if self.action in ['list', 'retrieve']:
            return ProductReadSerializer
        return ProductWriteSerializer


class CategoryModelViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer