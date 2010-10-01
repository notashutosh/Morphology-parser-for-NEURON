	/*
 * Copyright (C) 2010 Ashutosh Mohan
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

	
	/* SUBSTITUTIONS AND DEFINITIONS */
	
plusMinus	([+|-]*)
xPoint		({plusMinus}[0-9]+.[0-9]+)
yPoint		({plusMinus}[0-9]+.[0-9]+)
zPoint		({plusMinus}[0-9]+.[0-9]+)
digit		([0-9]+)
diameter	([0-9]+.[0-9]+)
space		([ ]*) 
coordinate	({xPoint}{space}{space}{yPoint}{space}{space}{zPoint})
coordinateAndDiam ({coordinate}{space}{diameter})
nextBranch	[|]
openParen	[(]
closeParen  [)]

/* Trivia: The computer is so damn smart that it doesn't really need to have subtitutions defined in the right order. It will figure it out even if the definition of a substition follows use. But since humans aren't so smart and tend to swear sometimes, I have defined them in order. Thank you for your time. Proceed further for some glamorous C definitions.*/

	
	/* C DEFINITIONS */
%{

	#include "y.tab.h"
	#define YYSTYPE char*
	extern YYSTYPE yySharedCoordinate;
	
%}


	
	/* RULES WITH CORRESPONDING HANDLERS */
%%

	/* Identifying cell body */
(CellBody)	{return CELLBODY;}
	
	/* Identifying axon */
(Axon)	{return AXON;}
	
	/* Identifying dendrite */
(Dendrite)	{return DENDRITE;}

	/* Identifying dendrite */
(Apical)	{return APICAL;}
	
	/* Identifying coordinates + diameter for everything except the soma. See substitutions above to decipher. */
{coordinateAndDiam}	{yySharedCoordinate = yytext;return COORDINATE_PLUS_DIAM;}

	/* identifying (, ) and | */

{openParen} {return LEFTPAREN;}
{closeParen} {return RIGHTPAREN;}
{nextBranch}	{return NEXTBRANCH;}
	
	/* THE FOLLOWING HAS TO BE AFTER ALL OTHER PATTERNS. Otherwise the program might not be able to detect parenthesis and that's pretty much the end of it all. RIP. */
	/* Things to ignore. It is alright if it is sometimes a subset of the following patterns because lex matches the longest string. In the future if need be, these will be moved down with the rest and handlers added. */
	
. 		/* Matching the generic 'any character' is needed to rid ourselves of the evils of control characters and the like. */
\n
{space}
\({space}(Color){space}(RGB){space}\([0-9]+,{space}[0-9]+,{space}[0-9]+\){space}\) /* so we can ignore 'Color RGB (x,y,z)'*/
\({space}(Resolution){space}({digit}.{digit})*\)	/* to ignore 'Resolution x' */
\"CellBody\"
\({space}(ImageCoords)(.)
\){space};{space}(End){space}(of){space}(ImageCoords)
(Merge){space}(.)*
(Coords){space}(.)*
	
	/* HANDLER FUNCTIONS */
%%

	//Defaults to return 1 since this program is designed to parse only single files. Return value of '1' signifies end of processing. This is called once lex finishes reading the current file.
int yywrap(void) {
	return 1;
}


int main(int argc, char** argv) {
	
	yyin = fopen(argv[1],"r");
	init(argv[1]);
	yyparse();
//	yylex();
	fclose(yyin);
}

