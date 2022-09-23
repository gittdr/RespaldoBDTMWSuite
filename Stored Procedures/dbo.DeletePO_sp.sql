SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[DeletePO_sp] @poh_identity INT, @userid VARCHAR(20)
AS

INSERT INTO PODeleteLog
		(usr_userid,
		 pdl_branch,
		 pdl_supplier,
		 pdl_plant,
		 pdl_deliverdate,
		 pdl_refnum,
		 pdl_deleted,
		 poh_identity)
SELECT @userid
	, poh_branch
	, poh_supplier
	, poh_plant
	, poh_deliverdate
	, poh_refnum
	, GetDate()
	, @poh_identity
FROM partorder_header
WHERE poh_identity = @poh_identity

DELETE partorder_header WHERE poh_identity = @poh_identity
DELETE partorder_detail WHERE poh_identity = @poh_identity
DELETE partorder_routing WHERE poh_identity = @poh_identity

DELETE partorder_header_history WHERE poh_identity = @poh_identity
DELETE partorder_detail_history WHERE poh_identity = @poh_identity
DELETE partorder_routing_history WHERE poh_identity = @poh_identity

GO
GRANT EXECUTE ON  [dbo].[DeletePO_sp] TO [public]
GO
