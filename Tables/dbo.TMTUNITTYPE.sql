CREATE TABLE [dbo].[TMTUNITTYPE]
(
[code] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[descript] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TMWDesignation] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TMTUNITTYPE_timestamp] ON [dbo].[TMTUNITTYPE] ([dw_timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMTUNITTYPE] TO [public]
GO
GRANT INSERT ON  [dbo].[TMTUNITTYPE] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMTUNITTYPE] TO [public]
GO
GRANT SELECT ON  [dbo].[TMTUNITTYPE] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMTUNITTYPE] TO [public]
GO
