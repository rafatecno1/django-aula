# - encoding:utf-8 -
from django.core.management.base import BaseCommand, CommandError
from django.core.mail import send_mail, get_connection
from django.core import mail
from aula import settings

from aula.apps.assignatures.models import UF, Assignatura
from aula.apps.alumnes.models import Alumne
from aula.apps.usuaris.models import Professor
from aula.apps.presencia.models import ControlAssistencia
from aula.apps.presencia.models import EstatControlAssistencia
from aula.apps.assignatures.models import UFAvisos
from aula.apps.horaris.models import Horari
from django.core import mail

from typing import List, Tuple

class Command(BaseCommand):

  class DadesMail():
    def __init__(self, **kwargs):
      self.assignatura = kwargs['assignatura'] #type: Assignatura
      self.llistaTo = kwargs['llistaTo'] #type: List[str]
      self.dadesAEnviar = kwargs['dadesAEnviar'] #type: List[Tuple[Alumne,UF,float,float]]

  """Envia correus als profes de tots els absentistes."""
  def handle(self, *args, **options):
    self.dadesEnviadesAUltimaTramesa = [] #type: List[DadesMail]
    try:
      assignatures=Assignatura.objects.filter(activar_notificacions=True)
      estatFalta=EstatControlAssistencia.objects.get(codi_estat='F')

      for assig in assignatures: #type: Assignatura
        dadesAEnviar=[]
        ufs=UF.objects.filter(assignatura=assig)
        for uf in ufs: #type: UF

          if assig.tipus_assignatura.tipus_assignatura.lower() == settings.CUSTOM_UNITAT_FORMATIVA_DISCONTINUADA:
            #Obtenir les dates i filtrar per controls, alerta molt costós.
            controls=ControlAssistencia.objects.filter(impartir__horari__assignatura = assig,
              impartir__dia_impartir__gte=uf.dinici, impartir__dia_impartir__lte=uf.dfi, 
              uf=uf)
            print "Controls:", controls
          else:
            #Obtenir les dates i filtrar per controls, alerta molt costós.
            controls=ControlAssistencia.objects.filter(impartir__horari__assignatura = assig,
              impartir__dia_impartir__gte=uf.dinici, impartir__dia_impartir__lte=uf.dfi)      

          #Seleccionar alumnes que apareguin a la llista de controls.
          alumnes = Alumne.objects.filter(pk__in = controls.values_list('alumne', flat=True).distinct()).order_by('cognoms')
          for alumn in alumnes:
            faltesAlumne = controls.filter(alumne=alumn, estat = estatFalta.id)
            #Calcular faltes totals injustificades.
            fi = len(faltesAlumne)
            tcpUF = (1.0*fi) / (1.0*uf.horesTeoriques) * 100

            if tcpUF >= assig.percent_primer_avis:
              self.stdout.write (u"Primer avís a:" + unicode(alumn) + u"--->" + unicode(uf.nom))
              avisos_realitzats = len(UFAvisos.objects.filter(assignatura=assig, alumne=alumn, nAvis=1))
              if avisos_realitzats == 0:
                dadesAEnviar.append((alumn, uf, assig.percent_primer_avis, tcpUF))
                self.stdout.write ("Envia mail!!")
                avis = UFAvisos(assignatura=assig, alumne=alumn, nAvis=1)
                avis.save()

            if tcpUF >= assig.percent_segon_avis:
              self.stdout.write (u"Segon avís a:" + unicode(alumn) + u"--->" + unicode(uf.nom))
              avisos_realitzats = len(UFAvisos.objects.filter(assignatura=assig, alumne=alumn, nAvis=2))
              if avisos_realitzats == 0:
                dadesAEnviar.append((alumn, uf, assig.percent_segon_avis, tcpUF))
                self.stdout.write ("Envia mail!!")
                avis = UFAvisos(assignatura=assig, alumne=alumn, nAvis=2)
                avis.save()
        
        if len(dadesAEnviar) != 0:
          #Enviament d'un sol correu amb les dades dels alumnes al profe(s) de l'assignatura, només si hi ha quelcom a enviar.
          #Selecciono profes.
          entrades_horaries=Horari.objects.filter(assignatura=assig, es_actiu=True).order_by('professor')
          profesSeleccionats = []
          anterior=-1
          for entrada in entrades_horaries:
            if entrada.professor != anterior:
              profesSeleccionats.append(entrada.professor.id)
            anterior = entrada.professor
          
          llistaTo= Professor.objects.filter(id__in=profesSeleccionats).values_list('email', flat=True)
          
          #Ara seleccionem els mails dels profes.
          self.stdout.write(u"--- Envio mail assignatura: {} a profe: {}, dades: {}".format(unicode(assig), unicode(llistaTo), str(dadesAEnviar).decode('utf')))
          #Anoto les dades enviades per fer debug.
          dm = Command.DadesMail(assignatura=assig, llistaTo=llistaTo, dadesAEnviar=dadesAEnviar)
          self.dadesEnviadesAUltimaTramesa.append(dm)   
          
          #self.stdout.write("--- DADES A L'ESTRUCTURA DE DADES")
          #for dm in self.dadesEnviadesAUltimaTramesa:
          #  self.stdout.write(u"reg: {} a profe: {}, dades: {}".format(unicode(dm.assignatura), unicode(dm.llistaTo), str(dm.dadesAEnviar).decode('utf')))

          #Envio mail.
          enviarMailAbsencies(llistaTo, dadesAEnviar)

      self.stdout.write("PROCES FINALITZAT CORRECTAMENT")
      return 0
    except Exception as e:
      self.stdout.write(u"ERROR" + unicode(e))
      import traceback
      traceback.print_exc()
      return 1

def enviarMailAbsencies(llistaTo, dadesAEnviar):
    """
      Envia un correu a tots els de la llistaTo (strings[])
      Les dades a enviar estan formades per una llista de tuples (alumne, uf, percentFaltes, tpcUF)
    """
    missatge = [ 
     u"Alumnes amb faltes d'assistència: " + dadesAEnviar[0][1].assignatura.nom_assignatura,
    ]

    for (alumne, uf, percentFaltes, tpcUF) in dadesAEnviar:
      liniaMsg = u"{0}, {1} ha superat el {2:.2f}% de faltes, ha realitzat un {3:.2f}%.".format(
        alumne.cognoms, alumne.nom, percentFaltes, tpcUF)
      missatge.append(liniaMsg)

    enviats = send_mail('Accés a infomes seguiment', 
            u'\n'.join( missatge ), 
            settings.EMAIL_HOST_USER,
            llistaTo, 
            fail_silently=False, connection=get_connection())
    return enviats
    #Per activar DEBUG, afegir paràmetre: connection=get_connection('django.core.mail.backends.console.EmailBackend')