SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[tmail_detailtab] (@stp varchar(20), @LD varchar(5), @MT varchar(5))

AS

/*
Purpose:  Returns XML formatted details for Omnitracs Workflow
Revision History:
Created
Modified - LB - 12/5/2013 - 9230 - Added/removed and resorted details for stops
Modified - LB - 01/31/2014 - 68401 - Added Temperature for SRT
Modified - Lori Brickley - 02/18/2014 - 68401 - Removed " from the contents of a reference number field

*/


BEGIN
	DECLARE @Pieces varchar(6),
									@Weight varchar(6),
									@Pallets varchar(6),
									@Temperature varchar(10),
									@Comments varchar(255),
									@Trl varchar(15),
									@Event varchar(50),
									@XML varchar(max)

									SET @XML = '<data id="InfoPlus">
					<datum name="type" value="details" />
					<data id="Info0">
					  <datum name="type" value="customItem" />
					  <datum name="sortId" value="1" />
					  <datum name="customLabel" value="Reference Information" />
					  <datum name="customValue" value=" " />
					</data>'


					select @XML = @XML + '<data id="Info1">
																					<datum name="type" value="customItem" />
																					<datum name="sortId" value="'+cast(isnull(ref_sequence+1,'') as varchar(50))+'" />
																					<datum name="customLabel" value="'+isnull(ref_type,'')+'" />
																					<datum name="customValue" value="'+isnull(replace(ref_number,'"',''),'')+'" />
																					</data>'
					from referencenumber (NOLOCK) where ref_table = 'Stops' and ref_tablekey = @stp


					select @Comments = stp_comment,@Pallets = CAST(stp_pallets_in as varchar(10)), @Pieces = CAST(stp_count as varchar(10)), @Weight = cast(stp_weight as varchar(10)) , @trl = evt_trailer1, @Event = eventcodetable.name
					from stops (NOLOCK)
									join event (NOLOCK) on stops.stp_number = event.stp_number 
									join eventcodetable (NOLOCK) on evt_eventcode = eventcodetable.abbr
	                                
					where stops.stp_number = @stp
									and evt_sequence = 1
	                                
		select @temperature = (cast(ord_mintemp as varchar(5)) + '-' + cast(ord_maxtemp as varchar(5)))
					from orderheader (Nolock)
					  join stops (nolock) on stops.ord_hdrnumber = orderheader.ord_hdrnumber
					where  stops.stp_number = @stp
	                                

									SELECT @XML = @XML + '<data id="InfoD1">
																					<datum name="type" value="customItem" />
																					<datum name="sortId" value="0" />
																					<datum name="customLabel" value="Event" />
																					<datum name="customValue" value="'+isnull(@Event,'')+'" />
																					</data>'
									SELECT @XML = @XML + '<data id="InfoD90">
																					<datum name="type" value="customItem" />
							<datum name="sortId" value="90" />
																					<datum name="customLabel" value="Total LD Miles" />
																					<datum name="customValue" value="'+isnull(@LD,'')+'" />
																					</data>'
									SELECT @XML = @XML + '<data id="InfoD91">
																					<datum name="type" value="customItem" />
																					<datum name="sortId" value="91" />
																					<datum name="customLabel" value="Total MT Miles" />
																					<datum name="customValue" value="'+isnull(@MT,'')+'" />
																					</data>'
									SELECT @XML = @XML + '<data id="InfoD92">
																					<datum name="type" value="customItem" />
																					<datum name="sortId" value="92" />
																					<datum name="customLabel" value="Trailer" />
																					<datum name="customValue" value="'+isnull(@Trl,'')+'" />
																					</data>'
									SELECT @XML = @XML + '<data id="InfoD93">
																					<datum name="type" value="customItem" />
																					<datum name="sortId" value="93" />
																					<datum name="customLabel" value="Temperature" />
																					<datum name="customValue" value="'+isnull(@Temperature,'')+'" />
																					</data>'                                               
									SELECT @XML = @XML + '<data id="InfoD94">
																					<datum name="type" value="customItem" />
																					<datum name="sortId" value="94" />
																					<datum name="customLabel" value="Pieces" />
																					<datum name="customValue" value="'+isnull(@Pieces,'')+'" />
																					</data>'
									SELECT @XML = @XML + '<data id="InfoD95">
																					<datum name="type" value="customItem" />
																					<datum name="sortId" value="95" />
																					<datum name="customLabel" value="Weight" />
																				   <datum name="customValue" value="'+isnull(@Weight,'')+'" />
																					</data>'
									SELECT @XML = @XML + '<data id="InfoD96">
																					<datum name="type" value="customItem" />
																					<datum name="sortId" value="96" />
																					<datum name="customLabel" value="Pallets" />
																					<datum name="customValue" value="'+isnull(@Pallets,'')+'" />
																					</data>'
									SELECT @XML = @XML + '<data id="InfoD97">
																					<datum name="type" value="customItem" />
																					<datum name="sortId" value="97" />
																					<datum name="customLabel" value="Comments" />
																					<datum name="customValue" value="'+isnull(REPLACE(@Comments,'"',''''),'')+'" />
																					</data>'
	                                                                                                                                                      
																select @xml = @xml + '</data>'

	select @XML

END

GO
GRANT EXECUTE ON  [dbo].[tmail_detailtab] TO [public]
GO
