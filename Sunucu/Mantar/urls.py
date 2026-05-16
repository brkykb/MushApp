from django.contrib import admin
from django.urls import path, include  # 'include' eklemeyi unutma
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('web.urls')),  # Ana sayfayı web app'e yönlendir
    path('api/', include('api.urls')), # Bunu sonra açacağız
]

# Medya dosyalarını (yüklenen resimleri) göstermek için gerekli
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)