CREATE TABLE [dbo].[assetassignment_tour_dtl]
(
[atd_id] [int] NOT NULL IDENTITY(1, 1),
[ath_id] [int] NOT NULL,
[asgn_number] [int] NOT NULL,
[lgh_number] [int] NOT NULL,
[last_updateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itut_assetassignment_tour_dtl]
ON [dbo].[assetassignment_tour_dtl]
FOR INSERT,UPDATE
AS

/**
 *
 * NAME:
 * dbo.itut_assetassignment_tour_dtl
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

   UPDATE assetassignment_tour_dtl
      SET last_updateby   = @last_updateby
        , last_updatedate = @last_updatedate
    WHERE atd_id IN (SELECT atd_id FROM inserted)
END
RETURN
GO
ALTER TABLE [dbo].[assetassignment_tour_dtl] ADD CONSTRAINT [pk_assetassignment_tour_dtl] PRIMARY KEY CLUSTERED ([atd_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_assetassignment_tour_dtl_asgn_number] ON [dbo].[assetassignment_tour_dtl] ([asgn_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_assetassignment_tour_dtl_ath_id] ON [dbo].[assetassignment_tour_dtl] ([ath_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_assetassignment_tour_dtl_lgh_number] ON [dbo].[assetassignment_tour_dtl] ([lgh_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[assetassignment_tour_dtl] ADD CONSTRAINT [fk_assetassignment_tour_dtl_asgn_number] FOREIGN KEY ([asgn_number]) REFERENCES [dbo].[assetassignment] ([asgn_number]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[assetassignment_tour_dtl] ADD CONSTRAINT [fk_assetassignment_tour_dtl_ath_id] FOREIGN KEY ([ath_id]) REFERENCES [dbo].[assetassignment_tour_hdr] ([ath_id]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[assetassignment_tour_dtl] ADD CONSTRAINT [fk_assetassignment_tour_dtl_lgh_number] FOREIGN KEY ([lgh_number]) REFERENCES [dbo].[legheader] ([lgh_number]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[assetassignment_tour_dtl] TO [public]
GO
GRANT INSERT ON  [dbo].[assetassignment_tour_dtl] TO [public]
GO
GRANT REFERENCES ON  [dbo].[assetassignment_tour_dtl] TO [public]
GO
GRANT SELECT ON  [dbo].[assetassignment_tour_dtl] TO [public]
GO
GRANT UPDATE ON  [dbo].[assetassignment_tour_dtl] TO [public]
GO
