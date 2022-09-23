SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[ef_get_routesync_options] (@lgh_number integer, @trc_number varchar (8), 
	@managed char(1) OUTPUT,
	@generate char(1) OUTPUT,
	@oor_distance decimal (4,1) OUTPUT, 
	@compliance integer OUTPUT)
AS
BEGIN
SET NOCOUNT ON
declare @rs_enabled char (1) 
select @rs_enabled = ISNull(LEFT (gi_string1, 1), 'N') from generalinfo where gi_name = 'fa_routesyncenabled'
select @generate = NULL, @managed = NULL, @oor_distance = NULL, @compliance = NULL
if @rs_enabled = 'Y' 
begin
	select @managed = ISNull(LEFT (gi_string1, 1), 'N') from generalinfo where gi_name = 'fa_rs_managed'
	select @generate = ISNull(LEFT (gi_string1, 1), 'N') from generalinfo where gi_name = 'fa_rs_generatemessage'
	select @oor_distance = cast (ISNull (gi_string1, '0.2') as decimal (4,1)) from generalinfo where gi_name = 'fa_rs_oordistance'
	select @compliance = cast (ISNull (gi_string1, '1') as integer) from generalinfo where gi_name = 'fa_rs_compliance'
end

END 
GO
GRANT EXECUTE ON  [dbo].[ef_get_routesync_options] TO [public]
GO
