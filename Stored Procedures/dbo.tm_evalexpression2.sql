SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**
 *
 * NAME:
 * dbo.tm_evalexpression2
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This is the stored procedure for the Evaluate Expression view.
 *
 * RETURNS:
 * n/a
 *
 * RESULT SETS:
 * The results of the executed @Expression
 *
 * PARAMETERS:
 * 001 - @Expression varchar(1500)
 * 002 - @Parm1 varchar(255)
 * 003 - @Parm2 varchar(255)
 * 004 - @Parm3 varchar(255)
 * 005 - @Parm4 varchar(255)
 * 006 - @Parm5 varchar(255)
 * 007 - @Parm6 varchar(255)
 * 008 - @Parm7 varchar(255)
 * 009 - @Parm8 varchar(255)
 * 010 - @Parm9 varchar(255)
 * 011 - @Parm10 varchar(255)
 * 012 - @Parm11 varchar(255)
 * 013 - @Parm12 varchar(255)
 * 014 - @Parm13 varchar(255)
 * 015 - @Parm14 varchar(255)
 * 016 - @Parm15 varchar(255)
 * 017 - @Parm16 varchar(255)
 * 018 - @Parm17 varchar(255)
 * 019 - @Parm18 varchar(255)
 * 020 - @Parm19 varchar(255)
 * 021 - @Parm20 varchar(255)
 *
 * REFERENCES: 
 * Calls: dbo.tm_sprint2
 *
 * REVISION HISTORY:
 * 05/10/2010.01 – PTS37001 - LB – New version with 20 parameters
 *
 **/

CREATE PROCEDURE [dbo].[tm_evalexpression2]
	@Expression varchar(1000),
	@Parm1 varchar(255)='',
	@Parm2 varchar(255)='',
	@Parm3 varchar(255)='',
	@Parm4 varchar(255)='',
	@Parm5 varchar(255)='',
	@Parm6 varchar(255)='',
	@Parm7 varchar(255)='',
	@Parm8 varchar(255)='',
	@Parm9 varchar(255)='',
	@Parm10 varchar(255)='',
	@Parm11 varchar(255)='',
	@Parm12 varchar(255)='',
	@Parm13 varchar(255)='',
	@Parm14 varchar(255)='',
	@Parm15 varchar(255)='',
	@Parm16 varchar(255)='',
	@Parm17 varchar(255)='',
	@Parm18 varchar(255)='',
	@Parm19 varchar(255)='',
	@Parm20 varchar(255)=''
AS

DECLARE @expressionwork as varchar(4096)
DECLARE @spwork as varchar(30)

SET NOCOUNT ON

SELECT @expressionwork = @expression
SELECT @parm1 = replace(isnull(@parm1, ''), '''', '''''')
SELECT @parm2 = replace(isnull(@parm2, ''), '''', '''''')
SELECT @parm3 = replace(isnull(@parm3, ''), '''', '''''')
SELECT @parm4 = replace(isnull(@parm4, ''), '''', '''''')
SELECT @parm5 = replace(isnull(@parm5, ''), '''', '''''')
SELECT @parm6 = replace(isnull(@parm6, ''), '''', '''''')
SELECT @parm7 = replace(isnull(@parm7, ''), '''', '''''')
SELECT @parm8 = replace(isnull(@parm8, ''), '''', '''''')
SELECT @parm9 = replace(isnull(@parm9, ''), '''', '''''')
SELECT @parm10 = replace(isnull(@parm10, ''), '''', '''''')
SELECT @parm11 = replace(isnull(@parm11, ''), '''', '''''')
SELECT @parm12 = replace(isnull(@parm12, ''), '''', '''''')
SELECT @parm13 = replace(isnull(@parm13, ''), '''', '''''')
SELECT @parm14 = replace(isnull(@parm14, ''), '''', '''''')
SELECT @parm15 = replace(isnull(@parm15, ''), '''', '''''')
SELECT @parm16 = replace(isnull(@parm16, ''), '''', '''''')
SELECT @parm17 = replace(isnull(@parm17, ''), '''', '''''')
SELECT @parm18 = replace(isnull(@parm18, ''), '''', '''''')
SELECT @parm19 = replace(isnull(@parm19, ''), '''', '''''')
SELECT @parm20 = replace(isnull(@parm20, ''), '''', '''''')

EXEC dbo.tm_sprint2 @Expressionwork out, @Parm1, @Parm2, @Parm3, @Parm4, @Parm5, @Parm6, @Parm7, @Parm8, @Parm9, @Parm10, @Parm11, @Parm12, @Parm13, @Parm14, @Parm15, @Parm16, @Parm17, @Parm18, @Parm19, @Parm20
SELECT @Expressionwork = 'SELECT ' + @expressionwork

EXEC (@Expressionwork)
GO
GRANT EXECUTE ON  [dbo].[tm_evalexpression2] TO [public]
GO
