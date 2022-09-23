SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[tmw_make_default_planning_record_master_ordnumber_sp](
		@shipper varchar(8), 
		@consignee varchar(8), 
		@cmd varchar(8),
		@billto varchar(8), 
		@orderby varchar(8), 
		@revtype1 varchar(6), 
		@revtype2 varchar(6), 
		@revtype3 varchar(6), 
		@revtype4 varchar(6), 
		@suggested_name varchar(12) OUTPUT)
AS

DECLARE @proctocall varchar(255),
	@sql nvarchar(1024)

SELECT @proctocall = IsNull(gi_string1, '')
FROM generalinfo
WHERE gi_name = 'AGGMASTERCREATEDEFAULTS'

If @proctocall > ''
BEGIN
 exec @proctocall @shipper, @consignee, @cmd, @billto, @orderby, @revtype1, @revtype2, @revtype3, @revtype4, @suggested_name OUTPUT
END


GO
GRANT EXECUTE ON  [dbo].[tmw_make_default_planning_record_master_ordnumber_sp] TO [public]
GO
