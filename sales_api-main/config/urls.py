from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    path('admin/', admin.site.urls),
    # Auth — siempre disponibles, necesarios solo cuando USE_JWT=true
    path('auth/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    # Apps
    path('product/', include('apps.product.urls')),
    path('client/', include('apps.client.urls')),
    path('sale/', include('apps.sale.urls')),
    path('provider/', include('apps.provider.urls')),

]