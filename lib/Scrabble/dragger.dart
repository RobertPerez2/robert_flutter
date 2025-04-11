// dragger_multi.dart

import "dart:math";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

const double TILE_SIZE = 30;

class Coords
{
  double x, y;
  Coords(this.x,this.y);
  double dist( Coords c )
  {
    double xd = c.x - x;
    double yd = c.y - y;
    return sqrt( xd*xd + yd*yd );
  }

  Coords.copy( Coords c ) : x = c.x, y = c.y ; 
}

class DragState
{
  List<Coords> zat; // position of each left corner of boxes
  // Coords zat; // position of left corner of draggable box
  Coords offset; // while being dragged, position of mouse inside box
  //bool dragging; // true iff being dragged
  int dragme = -1; // index in zat of box being dragged, -1 if none

  DragState( this.zat, this.offset, this.dragme );
}
class DragCubit extends Cubit<DragState>
{
  DragCubit( List<Coords> here) : super( DragState(here, Coords(0,0), -1 ) );

  // mouse goes down here, find the tile we are closest to,
  // mark that one (dragme), and note the offset
  void down( TapDownDetails td ) 
  { Coords mouse = Coords( td.localPosition.dx, td.localPosition.dy );
    int dragme = 0;
    double dragmed = 1000000;
    for ( int i=0; i<state.zat.length; i++ )
    {
      Coords p = Coords.copy(state.zat[i]); // center of square with next line
      p.x += TILE_SIZE/2;  p.y += TILE_SIZE/2;
      double d = mouse.dist(p); // how close is mouse to this tile
      if ( d < dragmed )
      { dragme = i;
        dragmed = d;
      }
    }

    Coords off = Coords( mouse.x - state.zat[dragme].x, 
                         mouse.y - state.zat[dragme].y 
                       );
    emit( DragState(state.zat, off, dragme ) );
  }
  // we are dragging, so set the zat from this positoin minus offset
  void drag( DragUpdateDetails td ) 
  { Coords mouse = Coords( td.localPosition.dx, td.localPosition.dy );
    Coords z = Coords( mouse.x - state.offset.x, mouse.y - state.offset.y );
    state.zat[state.dragme] = z;
    emit( DragState(state.zat, state.offset, state.dragme ) );
  }
  void up( DragEndDetails de )
  {
    emit( DragState(state.zat, Coords(0,0), -1 ) );
  }
}

class Tile extends Positioned
{ final String face;
  final Coords where;
  Tile(this.face, this.where)
  : super
    (
      left: where.x, top: where.y,
      child: Container
      ( height: TILE_SIZE, width: TILE_SIZE,
        decoration: BoxDecoration
        ( //color: Colors.black,
          border: Border.all(width:2),
          color: Colors.black,
          // shape: BoxShape.circle,
        ),
        child: Text(face, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: Colors.white) ),
      ),
    );
}