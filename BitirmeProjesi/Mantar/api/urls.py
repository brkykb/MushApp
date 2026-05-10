from django.urls import path
from .views import PredictAPIView, WikiListView, DailyMushroomView, UserCollectionView

urlpatterns = [
    path('predict/', PredictAPIView.as_view(), name='api_predict'),
    path('wiki/', WikiListView.as_view(), name='api_wiki'),
    path('daily/', DailyMushroomView.as_view(), name='api_daily'),
    path('collection/', UserCollectionView.as_view(), name='api_collection'),
]