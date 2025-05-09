"""tasks setup"""
from invoke import Collection

from tasks import idp
from tasks import payload

ns = Collection()

ns.add_collection(idp)
ns.add_collection(payload)
