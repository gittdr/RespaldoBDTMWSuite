SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.get_resource_status    Script Date: 6/1/99 11:54:32 AM ******/
CREATE PROCEDURE [dbo].[get_resource_status] 
	@drv1 varchar ( 8 ), 
	@drv2 varchar ( 8 ), 
	@trc varchar ( 8 ),
	@trl1 varchar ( 13 ),
	@trl2 varchar ( 13 )

AS

DECLARE @drv1stat char ( 6 ),
	@drv2stat char ( 6 ),
	@trcstat char ( 6 ),
	@trl1stat char ( 6 ),
	@trl2stat char ( 6 )


IF @drv1 <> 'UNKNOWN'
	SELECT @drv1stat = mpp_status
	FROM manpowerprofile
	WHERE mpp_id = @drv1
ELSE
	SELECT @drv1stat = 'AVL'

IF @drv2 <> 'UNKNOWN'
	SELECT @drv2stat = mpp_status
	FROM manpowerprofile
	WHERE mpp_id = @drv2
ELSE
	SELECT @drv2stat = 'AVL'

IF @trc <> 'UNKNOWN'
	SELECT @trcstat = trc_status
	FROM tractorprofile
	WHERE trc_number = @trc
ELSE
	SELECT @drv2stat = 'AVL'

IF @trl1 <> 'UNKNOWN'
	SELECT @trl1stat = trl_status
	FROM trailerprofile
	WHERE trl_id = @trl1
ELSE
	SELECT @trl1stat = 'AVL'

IF @trl2 <> 'UNKNOWN'
	SELECT @trl2stat = trl_status
	FROM trailerprofile
	WHERE trl_id = @trl2
ELSE
	SELECT @trl2stat = 'AVL'

SELECT @drv1stat,
	@drv2stat,
	@trcstat,
	@trl1stat,
	@trl2stat



GO
GRANT EXECUTE ON  [dbo].[get_resource_status] TO [public]
GO
