SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE      proc [dbo].[alias]
(
	@inToken nvarchar(50),
	@level int
) 
as

if (select count(*) from dbo.dx_alias WHERE (dbo.dx_alias.Token LIKE @inToken)) > 0
    begin
	SELECT     dbo.dx_alias.Token AS Original, dx_alias_1.Token, dx_alias_1.TokenGroup, dx_alias_1.Hook, @level
	FROM         dbo.dx_alias LEFT OUTER JOIN
	                      dbo.dx_alias dx_alias_1 ON dbo.dx_alias.TokenGroup = dx_alias_1.TokenGroup
	WHERE     (dbo.dx_alias.Token LIKE @inToken)
    end
else
    begin
	select @inToken,@intoken,0,1,@level
    end

GO
GRANT EXECUTE ON  [dbo].[alias] TO [public]
GO
