SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_AddPayDetailHrsMiles] (@sLgh varchar(10),
												@sQuantity varchar(20),
												@sHours varchar(20),
												@sMiles varchar(20),
												@DescPrefix varchar(45),	-- Will be Prepended to the pyd_description field
												@asgn_type varchar(6),
												@asgn_id varchar(13),
												@PayType varchar(6),
												@Flags varchar(10))

AS


EXEC dbo.tmail_AddPayDetailHrsMiles2 @sLgh,
					@sQuantity,
					@sHours,
					@sMiles,
					@DescPrefix,	-- Will be Prepended to the pyd_description field
					@asgn_type,
					@asgn_id,
					@PayType,
					@Flags,
					NULL,
					'',
					NULL
GO
GRANT EXECUTE ON  [dbo].[tmail_AddPayDetailHrsMiles] TO [public]
GO
