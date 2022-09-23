SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_get_archive]
(
	@dx_orderHdrNumber int
)
AS

/*******************************************************************************************************************  
  Object Description:
  dx_get_archive

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

SELECT dx_ident, dx_importid, dx_sourcename, dx_sourcedate, dx_seq, dx_updated, dx_accepted, dx_ordernumber, dx_orderhdrnumber, dx_movenumber, dx_stopnumber, dx_freightnumber, dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006, dx_field007, dx_field008, dx_field009, dx_field010, dx_field011, dx_field012, dx_field013, dx_field014, dx_field015, dx_field016, dx_field017, dx_field018, dx_field019, dx_field020, dx_field021, dx_field022, dx_field023, dx_field024, dx_field025, dx_field026, dx_field027, dx_field028, dx_field029, dx_field030 FROM dx_Archive WHERE (dx_orderhdrnumber = @dx_orderHdrNumber) AND (dx_importid = 'dx_204') ORDER BY dx_sourcedate DESC

GO
GRANT EXECUTE ON  [dbo].[dx_get_archive] TO [public]
GO
