CREATE TABLE [dbo].[stateminimumwagelog_hdr]
(
[smwlh_id] [int] NOT NULL IDENTITY(1, 1),
[processed_pay_period] [datetime] NOT NULL,
[applicable_pay_period_begin] [datetime] NOT NULL,
[applicable_pay_period_end] [datetime] NOT NULL,
[last_updateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itut_stateminimumwagelog_hdr]
ON [dbo].[stateminimumwagelog_hdr]
FOR INSERT,UPDATE
AS

/**
 *
 * NAME:
 * dbo.itut_stateminimumwagelog_hdr
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

   UPDATE stateminimumwagelog_hdr
      SET last_updateby   = @last_updateby
        , last_updatedate = @last_updatedate
    WHERE smwlh_id IN (SELECT smwlh_id FROM inserted)
END
RETURN
GO
ALTER TABLE [dbo].[stateminimumwagelog_hdr] ADD CONSTRAINT [pk_stateminimumwagelog_hdr] PRIMARY KEY CLUSTERED ([smwlh_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_stateminimumwagelog_hdr_processed_pay_period] ON [dbo].[stateminimumwagelog_hdr] ([processed_pay_period]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[stateminimumwagelog_hdr] TO [public]
GO
GRANT INSERT ON  [dbo].[stateminimumwagelog_hdr] TO [public]
GO
GRANT REFERENCES ON  [dbo].[stateminimumwagelog_hdr] TO [public]
GO
GRANT SELECT ON  [dbo].[stateminimumwagelog_hdr] TO [public]
GO
GRANT UPDATE ON  [dbo].[stateminimumwagelog_hdr] TO [public]
GO
