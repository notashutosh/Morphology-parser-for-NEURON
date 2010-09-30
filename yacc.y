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


%{
	#include<stdio.h>
	int yylex(void);
	void yyerror(char*);
%}

%token COORDINATE_PLUS_DIAM
%token NEURITE
%token CELLBODY
%token LEFTPAREN
%token RIGHTPAREN
%token NEXTBRANCH

%%
	file:		LEFTPAREN tree					{ printf("Case 0.5");$$ = $1 ;}
		;
		
	tree:		coordinate						{ printf("\t Case 0.2 - New point");$$ = $1 ;}
		|		tree coordinate					{ printf("\t Case 0.3 - New point");$$ = $1 ;}
		|		tree LEFTPAREN coordinate		{ printf("\t Case 1.1 - New split");$$ = $1 ;}
		|		tree NEXTBRANCH coordinate		{ printf("\tCase 1.2 - New sibling");$$ = $1 ;}
		|		tree RIGHTPAREN					{ printf("\tCase 1.3 - Ending");$$ = $1 ;}
		;
	coordinate:	LEFTPAREN primary RIGHTPAREN	{ printf("\t");$$ = $1 ;}
		;
	primary: 	COORDINATE_PLUS_DIAM			{ printf("(PNT)");$$ = $1 ;}
		|		CELLBODY						{ printf("(CB)");$$ = $1 ;}
		|		NEURITE							{ printf("(NEU)");$$ = $1 ;}
		;
%%

void yyerror(char* s )	{
	fprintf(stderr,"\n%s",s);
}

int init(int argc, char** argv) {
}