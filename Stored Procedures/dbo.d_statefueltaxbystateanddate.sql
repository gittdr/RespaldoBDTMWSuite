SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC	[dbo].[d_statefueltaxbystateanddate]
@state varchar(6),
@date datetime
AS

/************************************************************************************
 NAME:	          d_statefueltaxbystateanddate
 TYPE:		      stored procedure
 DATABASE:	      TMW
 PURPOSE:	      Retrieve state fuel tax by state and date
 DEPENDANCIES:

REVISION LOG

DATE		  WHO	   REASON
----		  ---	   ------
2010-02-24    vjh      Created.  	


exec d_statefueltaxbystateanddate 'OH', '2-25-2010'

*************************************************************************************/
declare @ldtm datetime

select [sft_id],
	[sftRate],
	[sftrateoverabove],
	[sftratepermile],
	[sftExcludeTollMiles]
from statefueltax
where sftState=@state
and sftdate=(select MAX(sftdate) from statefueltax where sftState=@state and sftDate<=@date)

GO
GRANT EXECUTE ON  [dbo].[d_statefueltaxbystateanddate] TO [public]
GO
