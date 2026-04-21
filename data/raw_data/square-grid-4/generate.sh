#!/usr/bin/bash

NODE_FILE="topology/net.nod.xml"
EDGE_FILE="topology/net.edg.xml"
CONNECTION_FILE="topology/net.con.xml"
TLS_LOGIC_FILE="topology/net.tls.xml"
TYPE_FILES="net.typ.xml"
NET_FILE="network/sim.net.xml"
TUNRDEF_FILE="turn.ratio.xml"
SINKS="A0bottom0,A1bottom1,A2bottom2,A3bottom3,D0top0,D1top1,D2top2,D3top3,A0left0,B0left1,C0left2,D0left3,A3right0,B3right1,C3right2,D3right3"

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
        --begin 0 --end 3600 --sinks $SINKS --seed=1

    echo "Demand file generated at $OUTPUT_FILE"
done

echo "All demand files generated."