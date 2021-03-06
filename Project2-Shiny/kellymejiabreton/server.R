library(shiny)
library(ggplot2)
library(wordcloud)
library(leaflet)
library(ggthemes)

shinyServer(function(input, output) {
        
        
        y <- reactive({
                
                #w=as.factor(input$boro)
                select(filter(df2, Borough==input$boro), Borough, Complaint.Type, Longitude, Latitude, MONTH, ANNUAL, DAY)
                #switch(input$dataset,
                 #      "Borough" = Borough,
                  #     "Month" = start.MMM,
                   #    "Year" = start.yr)
        })
        
        mapdata <- reactive({
          res = select(filter(df2, Borough==input$boro), Borough, Complaint.Type, Longitude, Latitude, MONTH, ANNUAL, DAY)
          return (res[complete.cases(res), ])
        })

        #maybe create a function where input$boro is the input
       
        # Fill in the spot we created for a plot
        output$barPlot <- renderPlot({
                # Render a barplot
                
                #ggplot(data = y(), aes(x= input$Fre_q)) + geom_bar()
                
                #w=y()[,input$Fre_q] data[,input$Fre_q]
               
                ggplot(data = y(), aes_string(x= input$Fre_q)) + 
                        geom_bar(colour="Green", fill="Blue")  +
                        facet_grid(~Borough) +
                        theme(axis.text = element_text(size = 16),
                              axis.title = element_text(size = 16))# + theme_gdocs()
        })
        
        #wordcloud_rep <- repeatable(wordcloud)
        
     

      
        
        
        output$wordCloud1 <- renderPlot({
                v <- y() 
                #par(mar=c(7,1,1,1))
                wordcloud(v$Complaint.Type, scale=c(15,5),min.freq=1,
                          max.words=100, random.order=FALSE, rot.per=0.15, colors= brewer.pal(8, "Paired"), vfont=c("sans serif","bold"))
                
                })
        
        #setView(-73.94197, 40.73638, zoom = 12) %>% 
        output$map <- renderLeaflet({
          mapdata <- select(filter(df2, Borough=="BROOKLYN"), Borough, Complaint.Type, Longitude, Latitude)
          mapdata <- mapdata[complete.cases((mapdata)),]
          
          ##########
          leaflet(data = mapdata) %>% addTiles() %>%
            setView(-73.95756, 40.71772, zoom = 17) %>%
            addMarkers(~Longitude, ~Latitude, popup = ~as.character(Complaint.Type),
                       clusterOptions = markerClusterOptions()) %>%
            addTiles()
          ##########
          # leaflet(data = mapdata) %>%
          #   setView(-73.95756, 40.71772, zoom = 17) %>%
          #   addMarkers(lng= ~Longitude, lat= ~Latitude, popup= ~as.character(Complaint.Type)) %>%
          #   addTiles()# Add default OpenStreetMap map tiles
        })
        
        observe({
          leafletProxy("map", data = mapdata()) %>%
            # clearMarkers() %>%
            # addMarkers(lng= ~Longitude, lat= ~Latitude, popup= ~Complaint.Type)
            ##############
            clearMarkerClusters() %>%
            addMarkers(~Longitude, ~Latitude, popup = ~as.character(Complaint.Type),
                       clusterOptions = markerClusterOptions())
            ##############
            
        })

        #select(filter(df2, Borough=="BROOKLYN"), Complaint.Type)
        
        
       
        output$table <- renderDataTable({
                head(group_by(filter(df2, Borough==input$boro), Complaint.Type) %>%
                        summarise(Count=n()) %>%
                        arrange(desc(Count)), n=10) %>%
                        rename(Complaint = Complaint.Type)
                
                })
        })        
