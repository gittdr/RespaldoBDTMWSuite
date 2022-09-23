SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC	[dbo].[d_legsonpyh] 
@pyh					INT
AS

/************************************************************************************
 NAME:	          d_legsonpyh
 TYPE:		      stored procedure
 DATABASE:	      TMW
 PURPOSE:	      Retrieve the lgh_numbers from all pay details on a pay header
 DEPENDANCIES:

REVISION LOG

DATE		  WHO	   REASON
----		  ---	   ------
2010-02-24    vjh      Created.  	


exec d_legsonpyh 6987 

*************************************************************************************/

select distinct(lgh_number)
from paydetail d
join payheader h on h.pyh_pyhnumber = d.pyh_number
where h.pyh_pyhnumber = @pyh and lgh_number <> 0 and lgh_number is not null

GO
GRANT EXECUTE ON  [dbo].[d_legsonpyh] TO [public]
GO
