SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_tank2] @cmp_id varchar(25), --PTS 61189 CMP_ID INCREASE LENGTH TO 25 
								@flags varchar(3), 
								@ordernumber varchar(30)

AS

SET NOCOUNT ON 

DECLARE @WhereClause varchar(200)
DECLARE @OrderByClause varchar(200)
DECLARE @sExec varchar(2000)

SET @WhereClause=' '
SET @OrderByClause = ' '

	IF @Flags & 1 <>0
		SET @WhereClause = ' and tank_inuse = ''Y'' '	
	IF @Flags & 2 <>0
		SET @OrderByClause = ' order by tank_loc '
	If @Flags & 4 <>0
		SET @WhereClause = @WhereClause + ' and tank_nbr IN (select fbc_tank_nbr from freight_by_compartment where ord_hdrnumber =  '+ @ordernumber + ') '

	SET @sExec =	'select tank_nbr, tank_model_id, tank_cmd_code, tank_capacity, tank_loc ' +
					'from tank ' +
					'where cmp_id= '''+@cmp_id +''' ' + @WhereClause + @OrderByClause

	--select @sExec
	EXEC (@sExec)
GO
GRANT EXECUTE ON  [dbo].[tm_tank2] TO [public]
GO
