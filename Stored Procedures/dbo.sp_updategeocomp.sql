SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[sp_updategeocomp]  (@lat float, @long float,  @comp varchar(20))

as

update company set  cmp_latseconds = (@lat*3600)   , cmp_longseconds = (-1* ((@long)*3600 ))        where cmp_id = @comp
GO
