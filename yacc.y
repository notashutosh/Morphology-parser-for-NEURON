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

/* The grammar in the file below might be expressed more elegantly and thus enable parsing of the code without ugly hacks. If you want to help, write to ashutoshmohan@gmail.com*/

%{
	#include<string.h>
	#include<stdio.h>
	
	//Dependent on corresponding lex definition
	#define YYSTYPE char*
	YYSTYPE yySharedCoordinate;

	//variables and definitions used for processing in this file
	FILE* yyout;
	int yyCurrentlyAccessed;
	int yyDendriteSectionCount = 0;
	int yyLastDendBifurcationIndex = 0;
	int yyApicalSectionCount = 0;
	int yyAxonSectionCount = 0;
	int yyCellBodyCount = 0;
	int lastToken = CELLBODY; //this is in many ways a hack. I should change grammar to remove the need to have this in here. The change in grammar should differentiate labels and coordinates, they've been clumped as primary at the moment.
	
	//function declarations.
	int yylex(void); //refers to the function in lex. The init() function in turn is called by lex.
	void yyerror(char*);
	void yyAdd3dPoint(char*);	
	void yyNewCellBodyContour();
	void yyNewDendrite();
	void yyNewDendriteBranch();
	void yyNewAxon();

%}

%token COORDINATE_PLUS_DIAM
%token APICAL
%token AXON
%token DENDRITE
%token CELLBODY
%token LEFTPAREN
%token RIGHTPAREN
%token NEXTBRANCH

%%
	file:		LEFTPAREN tree					{ ;}
		;
		
	tree:		tree LEFTPAREN coordinate		{if(lastToken == COORDINATE_PLUS_DIAM) { yyLastDendBifurcationIndex = yyDendriteSectionCount; ++yyDendriteSectionCount; yyNewDendriteBranch();yyAdd3dPoint(yySharedCoordinate) ;}}
		|		tree NEXTBRANCH coordinate		{if(lastToken == COORDINATE_PLUS_DIAM) {++yyDendriteSectionCount; yyNewDendriteBranch();yyAdd3dPoint(yySharedCoordinate) ;}}
		|		tree RIGHTPAREN					{;}
		|		coordinate						{ lastToken = COORDINATE_PLUS_DIAM; yyAdd3dPoint(yySharedCoordinate);}
		|		tree coordinate					{lastToken = COORDINATE_PLUS_DIAM; yyAdd3dPoint(yySharedCoordinate) ;}
		;
		
	coordinate:	LEFTPAREN primary RIGHTPAREN	{ ;}
		;
		
	primary: 	COORDINATE_PLUS_DIAM			{ ;}
		|		CELLBODY						{ lastToken = CELLBODY; yyCurrentlyAccessed = CELLBODY; ++yyCellBodyCount; yyNewCellBodyContour();}
		|		APICAL							{ lastToken = APICAL; yyCurrentlyAccessed = APICAL;}
		|		DENDRITE						{ lastToken = DENDRITE; yyCurrentlyAccessed = DENDRITE;++yyDendriteSectionCount; yyNewDendrite();}
		|		AXON							{ lastToken = AXON; yyCurrentlyAccessed = AXON;++yyAxonSectionCount;yyNewAxon();}
		;
%%

void yyAdd3dPoint(char* coordinateAndDiam)
{

	char x[7],y[7],z[7],diam[7]; //each point can have 7 chars. 
	char* temp;

if(yyCurrentlyAccessed != CELLBODY)	{
		fprintf(yyout,"h.pt3dadd(");
		int i = 0;
		for(i=0;i<4;i+=1)	{
			if(i==0)	{
				temp = (char*)strtok(coordinateAndDiam,"    ");
				if(temp == NULL)	{
					temp = (char*)strtok(coordinateAndDiam,"   ");
				}
			}
			else	{
				temp = (char*)strtok(NULL,"    ");
				if(temp == NULL)	{
					temp = (char*)strtok(coordinateAndDiam,"   ");
				}
			}
			if(i<3)	{ // so we won't add a comma for the last number
				fprintf(yyout,"%s,",temp);
			}
			else	{
				fprintf(yyout,"%s",temp);
			}
		}
		fprintf(yyout,"\n");
	}

	
	


}

void yyNewCellBodyContour()	{
//	fprintf(yyout,"soma = h.Section()")	;	
	fprintf(yyout,"NEW SOMA CONTOUR\n");
}

void yyerror(char* s )	{
	fprintf(stderr,"\n%s",s);
}

void yyNewDendrite()	{
	fprintf(yyout,"\n");
	fprintf(yyout,"dendrites.append(h.Section())\n");
	fprintf(yyout,"dendrites[%d].connect(soma)\n",yyDendriteSectionCount-1);
	fprintf(yyout,"h.pop_section()\n");
	fprintf(yyout,"dendrites[%d].push()\n",yyDendriteSectionCount-1);
}

void yyNewDendriteBranch()	{
	//fseek(yyout,-(strlen(yySharedCoordinate)+1+1),SEEK_CUR); // the first 1 accounts for the terminating character, the second one accounts for the 10 chars in h.add3dpoint( but also subtracts the 9 characters gained by replacing 12 spaces with 3 commas
	fprintf(yyout,"\n");
	fprintf(yyout,"dendrites.append(h.Section())\n");
	fprintf(yyout,"dendrites[%d].connect(dendrites[%d])\n",yyDendriteSectionCount-1,yyLastDendBifurcationIndex-1);
	fprintf(yyout,"h.pop_section()\n");
	fprintf(yyout,"dendrites[%d].push()\n",yyDendriteSectionCount-1);
	//this line was created with a programming hack. If you have problems parsing this file, this MIGHT be a good place to look.
//	fprintf(yyout,"h.addpt3d(%s\t\n",yySharedCoordinate);
//	yyAdd3dPoint(yySharedCoordinate);
}

void yyNewAxon()	{
	fprintf(yyout,"\n");
	fprintf(yyout,"axons.append(h.Section())\n");
	fprintf(yyout,"axons[%d].connect(soma)\n",yyAxonSectionCount-1);
	fprintf(yyout,"h.pop_section()\n");
	fprintf(yyout,"axons[%d].push()\n",yyAxonSectionCount-1);
}

int init(char* argv) {
	
	int outfileNameSize = strlen(argv)+3; //for appending .py
	char* outfileName = (char*)malloc(outfileNameSize*sizeof(char));
	strcpy(outfileName,argv);
	strcat(outfileName,".py");
	yyout = fopen(outfileName,"w");
	fprintf(yyout,"from neuron import *\n");
	fprintf(yyout,"from nrn import *\n");
	fprintf(yyout,"dendrites = []\n");	
	fprintf(yyout,"apicals = []\n");		
	fprintf(yyout,"axons = []\n");	

}