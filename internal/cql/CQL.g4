/*
# CQL2 Antlr grammar, with small modifications.
# - Additions: ILIKE

# Build: in this dir: antlr -Dlanguage=Go -package cql CQL.g4 CqlLexer.g4
#
# See examples:
# https://portal.ogc.org/files/96288#cql-bnf
# https://github.com/interactive-instruments/xtraplatform-spatial/tree/master/xtraplatform-cql/src/main/antlr/de/ii/xtraplatform/cql/infra
*/
parser grammar CQL;
options { tokenVocab=CqlLexer; contextSuperClass=CqlContext; }

/*============================================================================
# A CQL filter is a logically connected expression of one or more predicates.
#============================================================================*/

cqlFilter : booleanValueExpression EOF;
booleanValueExpression : booleanTerm | booleanValueExpression OR booleanTerm;
booleanTerm : booleanFactor | booleanTerm AND booleanFactor;
booleanFactor : ( NOT )? booleanPrimary;
booleanPrimary : predicate
                | LEFTPAREN booleanValueExpression RIGHTPAREN;

/*============================================================================
#  CQL supports scalar, spatial, temporal and existence predicates.
#============================================================================*/

predicate : binaryComparisonPredicate
            | likePredicate
            | betweenPredicate
            | isNullPredicate
            | inPredicate
            | spatialPredicate
            | distancePredicate
//            | temporalPredicate
//            | arrayPredicate
//            | existencePredicate
            ;

/*============================================================================
# A comparison predicate evaluates if two scalar expression statisfy the
# specified comparison operator.  The comparion operators include an operator
# to evaluate regular expressions (LIKE), a range evaluation operator and
# an operator to test if a scalar expression is NULL or not.
#============================================================================*/

binaryComparisonPredicate : arithmeticExpression ComparisonOperator arithmeticExpression;

likePredicate :  propertyName (NOT)? ( LIKE | ILIKE ) characterLiteral;

betweenPredicate : propertyName (NOT)? BETWEEN
                             arithmeticExpression AND arithmeticExpression ;
//                             (scalarValue | temporalExpression) AND (scalarValue | temporalExpression);

isNullPredicate : propertyName IS (NOT)? NULL;

/*============================================================================
# Arithmetic expressions
#============================================================================*/

arithmeticExpression : scalarValue
                    | LEFTPAREN arithmeticExpression RIGHTPAREN
                    | arithmeticExpression ArithmeticOperator arithmeticExpression
                    ;

/*
# A scalar value is a property name, a chracter literal, a numeric
# literal or a function/method invocation that returns a scalar value.
*/
scalarValue : propertyName
                    | characterLiteral
                    | numericLiteral
                    | booleanLiteral
//                    | function
                    ;

propertyName: Identifier;
characterLiteral: CharacterStringLiteral;
numericLiteral: NumericLiteral;
booleanLiteral: BooleanLiteral;

/*============================================================================
# A spatial predicate evaluates if two spatial expressions satisfy the
# specified spatial operator.
#============================================================================*/

spatialPredicate :  SpatialOperator LEFTPAREN geomExpression COMMA geomExpression RIGHTPAREN;

distancePredicate :  DistanceOperator LEFTPAREN geomExpression COMMA geomExpression COMMA NumericLiteral RIGHTPAREN;

/*
# A geometric expression is a property name of a geometry-valued property,
# a geometric literal (expressed as WKT) or a function that returns a
# geometric value.
*/
geomExpression : propertyName
               | geomLiteral
               /*| function*/;

/*============================================================================
# Definition of GEOMETRIC literals
#============================================================================*/

geomLiteral: point
             | linestring
             | polygon
             | multiPoint
             | multiLinestring
             | multiPolygon
             | geometryCollection
             | envelope;

point : POINT pointList;
pointList : LEFTPAREN coordinate RIGHTPAREN;
linestring : LINESTRING coordList;
polygon : POLYGON polygonDef;
polygonDef : LEFTPAREN coordList (COMMA coordList)* RIGHTPAREN;
multiPoint : MULTIPOINT LEFTPAREN pointList (COMMA pointList)* RIGHTPAREN;
multiLinestring : MULTILINESTRING LEFTPAREN coordList (COMMA coordList)* RIGHTPAREN;
multiPolygon : MULTIPOLYGON LEFTPAREN polygonDef (COMMA polygonDef)* RIGHTPAREN;
geometryCollection : GEOMETRYCOLLECTION LEFTPAREN geomLiteral (COMMA geomLiteral)* RIGHTPAREN;

envelope: ENVELOPE LEFTPAREN NumericLiteral COMMA NumericLiteral COMMA NumericLiteral  COMMA NumericLiteral RIGHTPAREN;

coordList: LEFTPAREN coordinate (COMMA coordinate)* RIGHTPAREN;
coordinate : NumericLiteral NumericLiteral;

/*============================================================================
# A temporal predicate evaluates if two temporal expressions satisfy the
# specified temporal operator.
#============================================================================*/
/*
temporalPredicate : temporalExpression (TemporalOperator | ComparisonOperator) temporalExpression;

temporalExpression : propertyName
                   | temporalLiteral
                   //| function
                   ;

temporalLiteral: TemporalLiteral;
*/

/*============================================================================
# The IN predicate
#============================================================================*/

inPredicate : propertyName NOT? IN LEFTPAREN (
        characterLiteral (COMMA characterLiteral)*
        | numericLiteral (COMMA numericLiteral)*
    ) RIGHTPAREN;