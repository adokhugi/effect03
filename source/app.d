import bindbc.sdl;

int[] gFrameBuffer;
SDL_Window* gSDLWindow;
SDL_Renderer* gSDLRenderer;
SDL_Texture* gSDLTexture;
static int gDone;
const int WINDOW_WIDTH = 800;
const int WINDOW_HEIGHT = 600;

bool update()
{
  SDL_Event e;
  if (SDL_PollEvent(&e))
  {
    if (e.type == SDL_EVENT_QUIT)
    {
      return false;
    }
    if (e.type == SDL_EVENT_KEY_UP && e.key.key == SDLK_ESCAPE)
    {
      return false;
    }
  }

  int* pix;
  int pitch;
  
  SDL_LockTexture(gSDLTexture, null, cast(void**)&pix, &pitch);
  for (int i = 0, sp = 0, dp = 0; i < WINDOW_HEIGHT; i++, dp += WINDOW_WIDTH, sp += WINDOW_WIDTH)
    for (int j = 0; j < WINDOW_WIDTH; j++)
    {
      *(pix + sp + j) = gFrameBuffer[dp + j];
    }

  SDL_UnlockTexture(gSDLTexture);  
  SDL_RenderTexture(gSDLRenderer, gSDLTexture, null, null);
  SDL_RenderPresent(gSDLRenderer);
  SDL_Delay(1);
  return true;
}

ulong render(ulong aTicks, ulong counter)
{
  import std.math.trigonometry;

  for (int i = 0, c = 0; i < WINDOW_HEIGHT; i++)
  {
    for (int j = 0; j < WINDOW_WIDTH; j++, c++)
    {
      int v = 0xff00ff00;
      if (aTicks - counter > 2500)
      {
        v >>= 8;
        counter = aTicks;
      }
      int t = cast(int)(i * j * cos(cast(float)aTicks / 10000)) | v & ~cast(int)(aTicks / 5000);
      gFrameBuffer[c] = cast(int)(t < 0xff00ff00 / 2 ? t * .8 : t * 1.2);
    }
  }

  return counter;
}

void loop()
{
  ulong counter = SDL_GetTicks();

  if (!update())
  {
    gDone = 1;
  }
  else
  {
    counter = render(SDL_GetTicks(), counter);
  }
}

void main()
{
  import core.stdc.stdio;

  printf("Starting...");

  loadSDL();

  if (!SDL_Init(SDL_INIT_VIDEO))
  {
    printf("SDL Init Failure");
    return;
  }

  gFrameBuffer = new int[WINDOW_WIDTH * WINDOW_HEIGHT];
  gSDLWindow = SDL_CreateWindow("SDL3 window", WINDOW_WIDTH, WINDOW_HEIGHT, 0);
  gSDLRenderer = SDL_CreateRenderer(gSDLWindow, null);
  gSDLTexture = SDL_CreateTexture(gSDLRenderer, SDL_PIXELFORMAT_ABGR8888, SDL_TEXTUREACCESS_STREAMING, WINDOW_WIDTH, WINDOW_HEIGHT);

  if (!gFrameBuffer || !gSDLWindow || !gSDLRenderer || !gSDLTexture)
  {
    printf("Other Error");
    return;
  }

  gDone = 0;
  while (!gDone)
  {
    loop();
  }

  SDL_DestroyTexture(gSDLTexture);
  SDL_DestroyRenderer(gSDLRenderer);
  SDL_DestroyWindow(gSDLWindow);
  SDL_Quit();

  return;
}
