# Livestreaming Shopping App

This sample project demonstrates livestreaming use-case in a shopping app.

### Authentication

This sample uses hardcoded users with hardcoded tokens. By the time you run the project, those tokens would most likely be expired. Therefore, make sure that you use your API key and tokens.

The `AppState` class contains the logic about the hardcoded users.

### Types of Users

There are 2 types of users in this sample:
- one host - the one that starts and controlls the livestream (also the person that sells products)
- vieweres - many viewers that watch the stream and can decide to buy products.

In this sample, the same `LivestreamView` is used for both types of users.

There's one important distinction though - the `LivestreamView` has a `isHost` bool that determines whether the view will work in host mode. In this case, an additional button for starting the livestream will be shown.

It's important to note that you can't join a livestream if it's in backstage. For more details about this topic, check our tutorial: https://getstream.io/video/sdk/ios/tutorial/livestreaming/.

Therefore, to have viewers join the stream, you need to first create and start the stream with the host.

### LivestreamView

The `LivestreamView` is the most important component in this sample. It contains the video rendering view, as well as some overlays that can enhance a shopping experience. It also has a chat integration.

In order for the chat integration to work, you also need to update the `ChatClient` setup in `AppState`, starting from line 33.

The chat doesn't only show messages, but also a welcome message and join events. It can easily be extended to add other types of events (e.g. leave events), for both chat and video.

There are several overlays with some sample navigation provided. 

#### Pinned Product

This is the pinned product that shows above the chat input field. It's controlled by the `pinnedProductShown` bool in the `LivestreamView`. It is shown as an overlay of the livestream view.

The default implementation shows a view called `LivestreamProductView`, which you can easily modify as needed.

#### Products View

This is the view on the left of the chat input view. It shows a list of products. It's controlled by the `productsViewShown` bool in the `LivestreamView`. 

The default implementation shows a view called `LivestreamProductsView`. It includes a list of products and navigating to a certain product.

#### Vouchers View

This is the view used to show a list of vouchers. It is controlled by the `vouchersShown` bool and it's represented by the `LivestreamVouchersView`.

#### Chat View

This is the view that shows the "comment" input field and the overlay messages. The data source for this view is the `LivestreamChatViewModel`.

The chat view itself is called `LivestreamChatView`.

#### Store View

This is the top left view, showing information about the store. The view is called `StoreView`.

#### Other helper views

There are other smaller views, such as the one for displaying the native share sheet or the participant count. You can easily find them in the code.