SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC	[dbo].[d_statefueltax] 
AS

/************************************************************************************
 NAME:	          d_statefueltax
 TYPE:		      stored procedure
 DATABASE:	      TMW
 PURPOSE:	      Retrieve the information in the statefueltax table
 DEPENDANCIES:

REVISION LOG

DATE		  WHO	   REASON
----		  ---	   ------
2010-02-24    vjh      Created.  	


exec d_statefueltax 

*************************************************************************************/

select 
	[sft_id],
	[sftState],
	[sftDate],
	[sftRate],
	[sftcreatedby],
	[sftcreatedate],
	[sftupdatedby],
	[sftupdatedate],
	[sftrateoverabove],
	[sftratepermile],
	[sftExcludeTollMiles]
from statefueltax

GO
GRANT EXECUTE ON  [dbo].[d_statefueltax] TO [public]
GO
