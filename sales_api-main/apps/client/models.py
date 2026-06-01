from django.db import models


class Client(models.Model):
    name = models.CharField(max_length=100)
    document_number = models.CharField(max_length=20, unique=True)

    def __str__(self):
        return f"{self.name} ({self.document_number})"