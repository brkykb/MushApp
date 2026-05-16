from django.urls import path
from .views import PredictAPIView, WikiListView, DailyMushroomView, UserCollectionView, FirebaseAuthView, ProfileView

urlpatterns = [
    path('auth/firebase/', FirebaseAuthView.as_view(), name='api_firebase_auth'),
    path('profile/', ProfileView.as_view(), name='api_profile'),
    path('predict/', PredictAPIView.as_view(), name='api_predict'),
    path('wiki/', WikiListView.as_view(), name='api_wiki'),
    path('daily/', DailyMushroomView.as_view(), name='api_daily'),
    path('collection/', UserCollectionView.as_view(), name='api_collection'),
]