SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC	[dbo].[d_fuelpurchasedforpyh]
@pyh					INT
AS

/************************************************************************************
 NAME:	          d_fuelpurchasedforpyh
 TYPE:		      stored procedure
 DATABASE:	      TMW
 PURPOSE:	      Retrieve fuelpurchased information for a payheader number
 DEPENDANCIES:

REVISION LOG

DATE		  WHO	   REASON
----		  ---	   ------
2010-02-24    vjh      Created.  	


exec d_fuelpurchasedforpyh 6987

Possibly look later to see if other records can be retrieved also.
ex. records that have no lgh_number, but match the order
or  records that have no lgh_number but fall within the daterange of one of the legs on any of the paydetails.

*************************************************************************************/
DECLARE @TT TABLE(
	[fp_id] [varchar](36) NOT NULL,
	[fp_sequence] [int] NOT NULL,
	[fp_date] [datetime] NULL,
	[fp_quantity] [money] NULL,
	[fp_uom] [varchar](6) NULL,
	[fp_fueltype] [varchar](6) NULL,
	[ord_number] [char](12) NULL,
	[ord_hdrnumber] [int] NULL,
	[mov_number] [int] NULL,
	[lgh_number] [int] NULL,
	[stp_number] [int] NULL,
	[trc_number] [varchar](8) NULL,
	[fp_state] [varchar](6) NULL
	)
	
	insert into @TT
	select 
	[f].[fp_id],
	[f].[fp_sequence],
	[f].[fp_date],
	[f].[fp_quantity],
	[f].[fp_uom],
	[f].[fp_fueltype],
	[f].[ord_number],
	[f].[ord_hdrnumber],
	[f].[mov_number],
	[f].[lgh_number],
	[f].[stp_number],
	[f].[trc_number],
	[f].[fp_state]
	
from fuelpurchased f
where f.lgh_number in (select distinct d.lgh_number from 
						payheader h
						join paydetail d on h.pyh_pyhnumber = d.pyh_number
						where h.pyh_pyhnumber = @pyh
						)
	
	select 
	[fp_id],
	[fp_sequence],
	[fp_date],
	[fp_quantity],
	[fp_uom],
	[fp_fueltype],
	[ord_number],
	[ord_hdrnumber],
	[mov_number],
	[lgh_number],
	[stp_number],
	[trc_number],
	[fp_state]
from @TT

GO
GRANT EXECUTE ON  [dbo].[d_fuelpurchasedforpyh] TO [public]
GO
