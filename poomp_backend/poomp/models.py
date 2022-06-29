from django.db import models

# Create your models here.
class Poomp(models.Model):
    date = models.DateField(auto_now_add= True)
    time = models.TimeField(auto_now_add= True)

    def save(self, *args, **kwargs):
        count_obj = Total_Count.objects.first()
        if not count_obj:
            count_obj = Total_Count.objects.create(count=0)
        
        count_obj.count += 1
        count_obj.save()

        return super(Poomp, self).save(*args, **kwargs)


class Total_Count(models.Model):
    count = models.BigIntegerField()