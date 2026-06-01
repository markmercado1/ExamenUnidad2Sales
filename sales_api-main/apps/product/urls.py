from apps.product.views import ProductModelViewSet, CategoryModelViewSet
from rest_framework import routers

router = routers.DefaultRouter()
router.register('products', ProductModelViewSet)
router.register('categories', CategoryModelViewSet)
urlpatterns = router.urls

