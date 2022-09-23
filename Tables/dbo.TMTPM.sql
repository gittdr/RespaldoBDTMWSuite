CREATE TABLE [dbo].[TMTPM]
(
[codekey] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[descript] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[compcode] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exp_priority] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMTPM] TO [public]
GO
GRANT INSERT ON  [dbo].[TMTPM] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMTPM] TO [public]
GO
GRANT SELECT ON  [dbo].[TMTPM] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMTPM] TO [public]
GO
