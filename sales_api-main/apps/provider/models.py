from django.db import models


class Provider(models.Model):
    nombre = models.CharField(max_length=100)
    ruc = models.CharField(max_length=11, unique=True)
    telefono = models.CharField(max_length=20)

    def __str__(self):
        return self.nombre