SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_gfc_pickform1000]
	@p_stp_number varchar(12),
	@p_gfc_sn varchar(12)
AS

SET NOCOUNT ON 

DECLARE
	@v_stp_number int,
	@v_gfc_sn int

if isnull(@p_stp_number,'') = '' 
	BEGIN
	RAISERROR ('Stop# required.', 16, 1)
	RETURN 1
	END
if isnumeric(@p_stp_number) = 0
	BEGIN
	RAISERROR ('Stop# must be numeric; got %s', 16, 1, @p_stp_number)
	RETURN 1
	END
set @v_stp_number = convert(int, @p_stp_number)

if isnull(@p_gfc_sn,'') = ''
	BEGIN
	RAISERROR ('Geofence parameters record# required.', 16, 1)
	RETURN 1
	END
if isnumeric(@p_gfc_sn) = 0
	BEGIN
	RAISERROR ('Geofence parameters record# must be numeric; got %s.', 16, 1, @p_gfc_sn)
	RETURN 1
	END
set @v_gfc_sn = convert(int, @p_gfc_sn)


/** CUSTOM BEGIN implementation of rule. **/

select gfc_auto_formid_occur 
from geofence_defaults (NOLOCK)
where sn = @v_gfc_sn

/** CUSTOM END implementation of rule. **/


RETURN 0
GO
GRANT EXECUTE ON  [dbo].[tmail_gfc_pickform1000] TO [public]
GO
