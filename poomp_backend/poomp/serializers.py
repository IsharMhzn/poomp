from rest_framework import serializers
from .models import Poomp, Total_Count

class PoompSerializer(serializers.ModelSerializer):
    class Meta:
        model = Poomp
        fields = "__all__"

# class TotalCountSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = Total_Count
#         fields = "__all__"