from django.shortcuts import render
from django.http import HttpResponse
from .models import Poomp, Total_Count
from .serializers import PoompSerializer
from rest_framework import generics, views

# Create your views here.
class CreatePoompView(generics.CreateAPIView):
    queryset = Poomp.objects.all()
    serializer_class  = PoompSerializer

class CountView(views.APIView):
    def get(self, request, format=None):
        counts = Total_Count.objects.all()
        count = 0
        for obj in counts:
            count += obj.count
        
        return HttpResponse(count)