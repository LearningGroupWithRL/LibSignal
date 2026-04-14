#!/usr/bin/bash

NODE_FILE="topology/net.nod.xml"
EDGE_FILE="topology/net.edg.xml"
CONNECTION_FILE="topology/net.con.xml"
TLS_LOGIC_FILE="topology/net.tls.xml"
TYPE_FILES="net.typ.xml"
NET_FILE="network/sim.net.xml"
TUNRDEF_FILE="turn.ratio.xml"
SINKS="A0bottom0,A1bottom1,A2bottom2,A3bottom3,A4bottom4,A5bottom5,A6bottom6,A7bottom7,A0left0,B0left1,C0left2,D0left3,E0left4,F0left5,G0left6,A7right0,B7right1,C7right2,D7right3,E7right4,F7right5,G7right6,G0top0,G1top1,G2top2,G3top3,G4top4,G5top5,G6top6,G7top7"

mkdir -p network

echo "Generating network files..."

netconvert \
    --node-files "$NODE_FILE" \
    --edge-files "$EDGE_FILE" \
    --connection-files "$CONNECTION_FILE" \
    --tllogic-files "$TLS_LOGIC_FILE" \
    --type-files "$TYPE_FILES" \
    --output-file "$NET_FILE" \
    --sidewalks.guess.max-speed=8.67 \
    --crossings.guess=true \
    --walkingareas=true \
    --junctions.corner-detail=5 \
    --junctions.limit-turn-speed=5.5 \
    --lefthand=false \
    --no-turnarounds=true

echo "Generating demand files..."
mkdir -p routes

for FLOW_FILE in flows/*.flow.xml; do
    VTYPE=$(basename "$FLOW_FILE")
    OUTPUT_FILE="routes/${VTYPE%.flow.xml}.rou.xml"

    echo "Processing $FLOW_FILE..."

    jtrrouter \
        --net-file=$NET_FILE \
        --route-files=$FLOW_FILE \
        --turn-ratio-files=$TUNRDEF_FILE \
        --output-file=$OUTPUT_FILE \
        --begin 0 --end 3600 -A --seed=1

    echo "Demand file generated at $OUTPUT_FILE"
done

echo "All demand files generated."