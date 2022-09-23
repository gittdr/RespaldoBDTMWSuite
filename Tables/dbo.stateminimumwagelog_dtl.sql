CREATE TABLE [dbo].[stateminimumwagelog_dtl]
(
[smwld_id] [int] NOT NULL IDENTITY(1, 1),
[smwlh_id] [int] NOT NULL,
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[applicable_taxable_pay] [money] NOT NULL,
[applicable_duty_hours] [decimal] (10, 4) NOT NULL,
[smw_id] [int] NOT NULL,
[last_updateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itut_stateminimumwagelog_dtl]
ON [dbo].[stateminimumwagelog_dtl]
FOR INSERT,UPDATE
AS

/**
 *
 * NAME:
 * dbo.itut_stateminimumwagelog_dtl
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
 * 08/10/2012 PTS63639 SPN - Initial Version
 **/
DECLARE @tmwuser                 VARCHAR(255)
DECLARE @last_updateby           VARCHAR(255)
DECLARE @last_updatedate         DATETIME

BEGIN
   EXEC gettmwuser @tmwuser OUTPUT

   SELECT @last_updateby = @tmwuser
   SELECT @last_updatedate = GETDATE()

   UPDATE stateminimumwagelog_dtl
      SET last_updateby   = @last_updateby
        , last_updatedate = @last_updatedate
    WHERE smwld_id IN (SELECT smwld_id FROM inserted)
END
RETURN
GO
ALTER TABLE [dbo].[stateminimumwagelog_dtl] ADD CONSTRAINT [pk_stateminimumwagelog_dtl] PRIMARY KEY CLUSTERED ([smwld_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_stateminimumwagelog_dtl_mpp_id] ON [dbo].[stateminimumwagelog_dtl] ([mpp_id]) INCLUDE ([smwld_id], [applicable_taxable_pay], [applicable_duty_hours], [smw_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_stateminimumwagelog_dtl_smw_id] ON [dbo].[stateminimumwagelog_dtl] ([smw_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_stateminimumwagelog_dtl_smwlh_id] ON [dbo].[stateminimumwagelog_dtl] ([smwlh_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[stateminimumwagelog_dtl] ADD CONSTRAINT [fk_stateminimumwagelog_dtl_smw_id] FOREIGN KEY ([smw_id]) REFERENCES [dbo].[stateminimumwage] ([smw_id])
GO
ALTER TABLE [dbo].[stateminimumwagelog_dtl] ADD CONSTRAINT [fk_stateminimumwagelog_dtl_smwlh_id] FOREIGN KEY ([smwlh_id]) REFERENCES [dbo].[stateminimumwagelog_hdr] ([smwlh_id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[stateminimumwagelog_dtl] TO [public]
GO
GRANT INSERT ON  [dbo].[stateminimumwagelog_dtl] TO [public]
GO
GRANT REFERENCES ON  [dbo].[stateminimumwagelog_dtl] TO [public]
GO
GRANT SELECT ON  [dbo].[stateminimumwagelog_dtl] TO [public]
GO
GRANT UPDATE ON  [dbo].[stateminimumwagelog_dtl] TO [public]
GO
