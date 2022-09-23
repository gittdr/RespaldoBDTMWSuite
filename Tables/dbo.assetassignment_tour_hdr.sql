CREATE TABLE [dbo].[assetassignment_tour_hdr]
(
[ath_id] [int] NOT NULL IDENTITY(1, 1),
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[free_stop_type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itut_assetassignment_tour_hdr]
ON [dbo].[assetassignment_tour_hdr]
FOR INSERT,UPDATE
AS

/**
 *
 * NAME:
 * dbo.itut_assetassignment_tour_hdr
 *
 * TYPE:
 * Trigger
 *
 * DESCRIPTION:
 * This trigger updates userid, last update date
 *
 * RETURNS:
 * None
 *
 * RESULT SETS:
 * NONE.
 *
 * PARAMETERS:
 * NONE
 *
 * REFERENCES:

 *
 * REVISION HISTORY:
 * 08/28/2012 PTS64367 SPN - Initial Version
 **/
DECLARE @tmwuser                 VARCHAR(255)
DECLARE @last_updateby           VARCHAR(255)
DECLARE @last_updatedate         DATETIME

BEGIN
   EXEC gettmwuser @tmwuser OUTPUT

   SELECT @last_updateby = @tmwuser
   SELECT @last_updatedate = GETDATE()

   UPDATE assetassignment_tour_hdr
      SET last_updateby   = @last_updateby
        , last_updatedate = @last_updatedate
    WHERE ath_id IN (SELECT ath_id FROM inserted)
END
RETURN
GO
ALTER TABLE [dbo].[assetassignment_tour_hdr] ADD CONSTRAINT [pk_assetassignment_tour_hdr] PRIMARY KEY CLUSTERED ([ath_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_assetassignment_tour_hdr_asgn_type_asgn_id] ON [dbo].[assetassignment_tour_hdr] ([asgn_type], [asgn_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[assetassignment_tour_hdr] TO [public]
GO
GRANT INSERT ON  [dbo].[assetassignment_tour_hdr] TO [public]
GO
GRANT REFERENCES ON  [dbo].[assetassignment_tour_hdr] TO [public]
GO
GRANT SELECT ON  [dbo].[assetassignment_tour_hdr] TO [public]
GO
GRANT UPDATE ON  [dbo].[assetassignment_tour_hdr] TO [public]
GO
