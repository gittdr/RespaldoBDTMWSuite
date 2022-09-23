CREATE TABLE [dbo].[stateminimumwage]
(
[smw_id] [int] NOT NULL IDENTITY(1, 1),
[country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[effective_date] [datetime] NOT NULL,
[hourly_rate] [decimal] (10, 4) NOT NULL,
[last_updateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itut_stateminimumwage]
ON [dbo].[stateminimumwage]
FOR INSERT,UPDATE
AS

/**
 *
 * NAME:
 * dbo.itut_stateminimumwage
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

   UPDATE stateminimumwage
      SET last_updateby   = @last_updateby
        , last_updatedate = @last_updatedate
    WHERE smw_id IN (SELECT smw_id FROM inserted)
END
RETURN
GO
ALTER TABLE [dbo].[stateminimumwage] ADD CONSTRAINT [pk_stateminimumwage] PRIMARY KEY CLUSTERED ([smw_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_stateminimumwage_country_state_effective_date] ON [dbo].[stateminimumwage] ([country], [state], [effective_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[stateminimumwage] TO [public]
GO
GRANT INSERT ON  [dbo].[stateminimumwage] TO [public]
GO
GRANT REFERENCES ON  [dbo].[stateminimumwage] TO [public]
GO
GRANT SELECT ON  [dbo].[stateminimumwage] TO [public]
GO
GRANT UPDATE ON  [dbo].[stateminimumwage] TO [public]
GO
