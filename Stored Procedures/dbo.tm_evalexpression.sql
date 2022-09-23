SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**
 *
 * NAME:
 * dbo.tm_evalexpression
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
 *
 * REFERENCES: 
 * Calls: dbo.tm_sprint
 *
 * REVISION HISTORY:
 * 05/24/2006.01 – PTS33187 - MZ – Lengthened @Expression from varchar(255) to varchar(1000)
 *
 **/

CREATE PROCEDURE [dbo].[tm_evalexpression]
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
	@Parm10 varchar(255)=''
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

--EXEC dbo.tm_sprint @Expressionwork out, @Parm1, @Parm2, @Parm3, @Parm4, @Parm5, @Parm6, @Parm7, @Parm8, @Parm9, @Parm10
EXEC dbo.tm_sprint2 @Expressionwork out, @Parm1, @Parm2, @Parm3, @Parm4, @Parm5, @Parm6, @Parm7, @Parm8, @Parm9, @Parm10,'','','','','','','','','',''
SELECT @Expressionwork = 'SELECT ' + @expressionwork

EXEC (@Expressionwork)
GO
GRANT EXECUTE ON  [dbo].[tm_evalexpression] TO [public]
GO
