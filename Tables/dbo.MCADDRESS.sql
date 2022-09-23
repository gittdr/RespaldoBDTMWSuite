CREATE TABLE [dbo].[MCADDRESS]
(
[MCA_NAMETYPE] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MCA_NAME] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MCA_SERVICE] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCA_ADDRESS] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCA_DESCRIPTION] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCA_DEFAULTRECIPTYPE] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCA_DEFAULTRECIPNAME] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCA_HWMUSERALIAS] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCA_HWMNEXTSEQUENCE] [smallint] NULL,
[MCA_GROUPDEFINED] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCA_GROUPINCLUDEALL] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Trigger dbo.td_MCADDRESS    Script Date: 6/1/99 11:55:18 AM ******/
---3.7.15  12/17/97
/****** Object:  Trigger dbo.td_MCADDRESS    Script Date: 12/10/97 5:50:30 PM ******/
create trigger [dbo].[td_MCADDRESS] on [dbo].[MCADDRESS] for delete as
begin
	                                                                  
  DELETE MCGROUP  
    FROM MCGROUP,   
         deleted  
   WHERE ( MCGROUP.MCG_NAMETYPE = deleted.MCA_NAMETYPE ) AND  
         ( MCGROUP.MCG_NAME = deleted.MCA_NAME )
	                                          
  DELETE MCGROUP  
    FROM MCGROUP,   
         deleted  
   WHERE ( MCGROUP.MCG_GROUP = deleted.MCA_NAME ) AND  
         ( deleted.MCA_NAMETYPE = 'GROUP' )
	  
end



GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_typename] ON [dbo].[MCADDRESS] ([MCA_NAMETYPE], [MCA_NAME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_servaddr] ON [dbo].[MCADDRESS] ([MCA_SERVICE], [MCA_ADDRESS]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MCADDRESS] TO [public]
GO
GRANT INSERT ON  [dbo].[MCADDRESS] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MCADDRESS] TO [public]
GO
GRANT SELECT ON  [dbo].[MCADDRESS] TO [public]
GO
GRANT UPDATE ON  [dbo].[MCADDRESS] TO [public]
GO
