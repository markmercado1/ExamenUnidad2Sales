from decimal import Decimal
from django.db import transaction
from rest_framework import serializers

from apps.client.serializers import ClientSerializer
from apps.product.serializers import ProductReadSerializer
from apps.sale.models import Sale, SaleDetail


# ── Detail serializers ────────────────────────────────────────────────────────

class SaleDetailReadSerializer(serializers.ModelSerializer):
    product = ProductReadSerializer(read_only=True)

    class Meta:
        model = SaleDetail
        fields = ['id', 'product', 'quantity', 'price', 'subtotal']


class SaleDetailWriteSerializer(serializers.Serializer):
    product = serializers.PrimaryKeyRelatedField(
        queryset=__import__('apps.product.models', fromlist=['Product']).Product.objects.all()
    )
    quantity = serializers.IntegerField(min_value=1)


# ── Sale serializers ──────────────────────────────────────────────────────────

class SaleReadSerializer(serializers.ModelSerializer):
    client = ClientSerializer(read_only=True)
    details = SaleDetailReadSerializer(many=True, read_only=True)

    class Meta:
        model = Sale
        fields = ['id', 'client', 'created_at', 'subtotal', 'igv', 'total', 'details']


class SaleWriteSerializer(serializers.Serializer):
    client = serializers.PrimaryKeyRelatedField(
        queryset=__import__('apps.client.models', fromlist=['Client']).Client.objects.all()
    )
    details = SaleDetailWriteSerializer(many=True)

    def validate_details(self, value):
        if not value:
            raise serializers.ValidationError("La venta debe tener al menos un detalle.")
        return value

    @transaction.atomic
    def create(self, validated_data):
        client = validated_data['client']
        details_data = validated_data['details']

        IGV_RATE = Decimal('0.18')

        # Calcular subtotales por detalle
        subtotal_venta = Decimal('0.00')
        details_to_create = []

        for item in details_data:
            product = item['product']
            quantity = item['quantity']
            price = product.price
            subtotal_detalle = price * quantity
            subtotal_venta += subtotal_detalle

            details_to_create.append(SaleDetail(
                product=product,
                quantity=quantity,
                price=price,
                subtotal=subtotal_detalle,
            ))

        igv = (subtotal_venta * IGV_RATE).quantize(Decimal('0.01'))
        total = subtotal_venta + igv

        # Crear la venta
        sale = Sale.objects.create(
            client=client,
            subtotal=subtotal_venta,
            igv=igv,
            total=total,
        )

        # Asignar FK y crear detalles en bulk
        for detail in details_to_create:
            detail.sale = sale
        SaleDetail.objects.bulk_create(details_to_create)

        return sale